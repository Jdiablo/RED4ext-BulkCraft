#include <stdafx.hpp>

#include <chrono>
#include <set>
#include <tchar.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>

#include <Workers/CraftingController.hpp>

#define RED4EXT_EXPORT extern "C" __declspec(dllexport)

CraftingController _craftingWorker = CraftingController();

std::string rootPath;

void InitializeLogger(std::filesystem::path aRoot)
{
    auto console = std::make_shared<spdlog::sinks::stdout_color_sink_st>();
    auto file = std::make_shared<spdlog::sinks::basic_file_sink_st>(aRoot / L"bulkcraft.log", true);

    spdlog::sinks_init_list sinks = { console, file };

    auto logger = std::make_shared<spdlog::logger>("", sinks);
    spdlog::set_default_logger(logger);

#ifdef _DEBUG
    logger->flush_on(spdlog::level::trace);
    spdlog::set_level(spdlog::level::trace);
#else
    logger->flush_on(spdlog::level::info);
    spdlog::set_level(spdlog::level::info);
#endif
}


RED4EXT_EXPORT void OnBaseInitialization()
{
    char buff[MAX_PATH];
    GetModuleFileNameA(NULL, buff, MAX_PATH);

    rootPath = std::string(buff);
    size_t pos = std::string::npos;
    std::string toErase = "Cyberpunk2077.exe";
    // Search for the substring in string in a loop untill nothing is found
    while ((pos = rootPath.find(toErase)) != std::string::npos)
    {
        // If found then erase it from string
        rootPath.erase(pos, toErase.length());
    }
    InitializeLogger(rootPath);
    
}

RED4EXT_EXPORT void OnInitialization()
{
    
}


RED4EXT_EXPORT void OnShutdown()
{
    
}


RED4EXT_EXPORT void OnUpdate()
{    
    static auto timeStart = std::chrono::high_resolution_clock::now();
    static auto loadCheck = std::chrono::high_resolution_clock::now();
    static bool initialized = false;
    static bool hudManagerInitialized = false;
    static bool trackerFound = false;

    auto now = std::chrono::high_resolution_clock::now();
    auto static gameInstance = RED4ext::CGameEngine::Get()->framework->gameInstance;
    using namespace std::chrono_literals;
    auto rtti = RED4ext::CRTTISystem::Get();

    if (!initialized && (now - timeStart) >= 5s)
    {
        initialized = true;
        _craftingWorker.Init();
    }
    if (!initialized)
        return;

    _craftingWorker.Work();
}

#include <stdafx.hpp>

#include <chrono>
#include <set>
#include <tchar.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>

#include <Workers/CraftingController.hpp>

#define RED4EXT_EXPORT extern "C" __declspec(dllexport)

CraftingController _craftingWorker = CraftingController();

RED4EXT_EXPORT void OnBaseInitialization()
{
    
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
        
        _craftingWorker.Init(rtti, gameInstance);
    }
    if (!initialized)
        return;

    _craftingWorker.Work();
}

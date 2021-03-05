#include "stdafx.hpp"
#include "CraftingController.hpp"

void CraftingController::Init(RED4ext::CRTTISystem* rtti, RED4ext::GameInstance* gameInstance)
{
    _gameInstance = gameInstance;
    _rtti = rtti;
    
    _openPicker = _rtti->GetClass("CraftingMainGameController")->GetFunction("OpenQuantityPicker");
}

void CraftingController::OpenQuantityPicker()
{
    try
    {
        RED4ext::Handle<RED4ext::IScriptable> player;
        auto uiCraftingDefcls = _rtti->GetClass("UI_CraftingDef");

        std::vector<RED4ext::CStackType> args;
        args.emplace_back(nullptr, &_gameInstance);

        if (_allBlackboardDef.GetPtr() == nullptr)
            RED4ext::ExecuteGlobalFunction("GetAllBlackboardDefs", &_allBlackboardDef, {});

        if (_allBlackboardDef.GetPtr() == nullptr)
            return;

        RED4ext::Handle<RED4ext::IScriptable> uiCrafting =
          _rtti->GetClass("gamebbAllScriptDefinitions")
            ->GetProperty("UI_Crafting")
            ->GetValue<RED4ext::Handle<RED4ext::IScriptable>>(_allBlackboardDef);

        RED4ext::WeakHandle<RED4ext::IScriptable> craftingCtrlr =
          uiCraftingDefcls->GetProperty("CraftingController")
            ->GetValue<RED4ext::WeakHandle<RED4ext::IScriptable>>(uiCrafting);

        if (!craftingCtrlr.GetUseCount())
            return;

        RED4ext::ExecuteFunction(craftingCtrlr.Lock(), _openPicker, nullptr, {});
    }
    catch (...)
    {
    }
}

void CraftingController::Work()
{
    if (GetAsyncKeyState('Z'))
    {
        OpenQuantityPicker();
    }
}

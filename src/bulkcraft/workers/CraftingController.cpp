#include "stdafx.hpp"
#include "CraftingController.hpp"

void CraftingController::Init()
{
    BaseInkWidgetController::Init();
    _craftingRootProp = _inkWidgetControllerCls->GetProperty("craftingRoot");
    _buttonHintsControllerProp = _inkWidgetControllerCls->GetProperty("buttonHintsController");

    _onQuantityPickerPopupClosedF = _inkWidgetControllerCls->GetFunction("OnQuantityPickerPopupClosed");

    auto buttonHintsCls = _rtti->GetClass("ButtonHints");
    for (auto& f : buttonHintsCls->funcs)
    {
        if (f->fullName == "AddButtonHint;CNameString")
        {
            _addButtonHint = f;
            break;
        }
    }

    _isVisibleF = _rtti->GetClass("inkCompoundWidgetReference")->GetFunction("IsVisible");
}

bool CraftingController::IsVisible()
{
    std::vector<RED4ext::CStackType> args;
    for (auto& so : GetScriptObjects())
    {
        auto craftingRoot = _craftingRootProp->GetValue<RED4ext::IScriptable*>(so);
        if (!craftingRoot)
            return false;

        bool visible = false;
        args.emplace_back(nullptr, craftingRoot);
        RED4ext::ExecuteFunction(craftingRoot, _isVisibleF, &visible, args);

        return visible;
    }
}

bool CraftingController::AddHintButton()
{
    if (_hintAdded)
        return false;

    std::vector<RED4ext::CStackType> args;
    for (auto& so : GetScriptObjects())
    {
        args.clear();
        RED4ext::CName action = "disassemble_item";
        args.emplace_back(nullptr, &action);
        RED4ext::CString label = "Bulk craft";
        args.emplace_back(nullptr, &label);
        auto buttonHintsController = _buttonHintsControllerProp->GetValue<RED4ext::WeakHandle<RED4ext::IScriptable>>(so);
        RED4ext::ExecuteFunction(buttonHintsController.Lock().GetPtr(), _addButtonHint, nullptr, args);
        _hintAdded = true;
    }
    return true; 
}

void CraftingController::OpenQuantityPicker()
{
    if (_quantityPickerShow)
        return;

    for (auto& so : GetScriptObjects())
    {
        RED4ext::ExecuteFunction(so, _inkWidgetControllerCls->GetFunction("OpenQuantityPicker"), nullptr, {});
        return;
    }
}

void CraftingController::Work()
{
    if (!Exist())
    {
        _hintAdded = false;
        _quantityPickerShow = false;
    }

    if (!IsVisible())
        return;

    AddHintButton();

    if (GetAsyncKeyState('Z'))
    {
        OpenQuantityPicker();
    }
}

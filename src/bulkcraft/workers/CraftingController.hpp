#include "workers/BaseInkWidgetController.hpp"

class CraftingController : CyberEyeTracking::Workers::BaseInkWidgetController
{
private:
    RED4ext::CProperty* _craftingRootProp;
    RED4ext::CProperty* _buttonHintsControllerProp;
    RED4ext::CClassFunction* _addButtonHint;
    RED4ext::CClassFunction* _isVisibleF;
    RED4ext::CClassFunction* _onQuantityPickerPopupClosedF;

    bool _hintAdded = false;
    bool _quantityPickerShow = false;
    bool AddHintButton();
    bool IsVisible();
    void OpenQuantityPicker();
public:
    CraftingController() : BaseInkWidgetController("CraftingMainGameController"){};
    ~CraftingController() = default;
    void Init();
    void Work();
};

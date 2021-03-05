class CraftingController
{
private:
    RED4ext::GameInstance* _gameInstance;
    RED4ext::CRTTISystem* _rtti;
    RED4ext::CClassFunction* _openPicker;
    RED4ext::Handle<RED4ext::IScriptable> _playerInstance;
    RED4ext::Handle<RED4ext::IScriptable> _allBlackboardDef;
    void OpenQuantityPicker();
public:
    CraftingController() = default;
    ~CraftingController() = default;
    void Init(RED4ext::CRTTISystem* rtti, RED4ext::GameInstance* gameInstance);
    void Work();
};

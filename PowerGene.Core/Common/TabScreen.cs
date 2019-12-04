using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.Core.Helpers;
using PowerGene.Core.Managers.PowerShells;
using PowerGene.Core.Managers.Projects;
using PowerGene.Core.Models.Common;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace PowerGene.Core.Common
{
    public abstract class TabScreen : Screen, ITabView
    {
        protected const string MODULE_SECTION_KEY = "Modules";

        protected readonly IProjectManager _projectManager;
        protected readonly IEventAggregator _eventAggregator;
        protected readonly IPowerShellManager _powerShellManager;

        public abstract int Order { get; }

        public abstract string ModuleKeyName { get; }

        public TabScreen(IProjectManager projectManager, IEventAggregator eventAggregator, IPowerShellManager powerShellManager)
        {
            _projectManager = projectManager;
              _eventAggregator = eventAggregator;
            _powerShellManager = powerShellManager;

            eventAggregator.Subscribe(this);
            _powerShellManager.Message += ((s, e) => _eventAggregator.PublishOnCurrentThread(new LogEvent(e)));
        }

        protected virtual void RunScript(object obj, IObservableCollection<NotifyKeyItemBase> actions, object selectedItem, int projectEventType)
        {
            if (obj == null)
            {
                obj = actions.FirstOrDefault(x => ((dynamic)x.Value).IsDefault);
            }

            if (obj != null)
            {
                dynamic objz = obj.ToDictionary().DictionaryToObject();

                string key = objz.Key;
                string scriptPath = objz.Value.Path;
                bool isContext = objz.Value.IsContext;

                bool run = false;

                run = true;
                if (run)
                {
                    var item = _projectManager.Model.GetDictOrInit(ModuleKeyName)
                        .FirstOrDefault(x => x.Value == selectedItem);
                    _projectManager.Model.ProcessItem.Clear();
                    if (isContext)
                    {
                        _projectManager.Model.ProcessItem.Add(item.Key, item.Value);
                    }

                    Hashtable model = _powerShellManager.Run<Hashtable>(scriptPath, _projectManager.Model);
                    var projectModel = _projectManager.Reload(model);

                    _eventAggregator.PublishOnUIThread(new ProjectEventBase
                    (
                        projectModel,
                        projectEventType
                    ));
                }
            }
        }

        protected virtual Dictionary<string, object> ReturnScriptModuleDictionary(string key)
        {
            var result = new Dictionary<string, object>();

            var module = _projectManager.Model.Scripts.ContainsKey(MODULE_SECTION_KEY) ? _projectManager.Model.Scripts[MODULE_SECTION_KEY] : null;
            if (module == null) return result;

            var moduleDict = module.ToDictionary();
            var specificPart = moduleDict.ContainsKey(key) ? moduleDict[key] : null;
            if (specificPart == null) return result;

            result = specificPart.ToDictionary();

            return result;
        }
    }
}

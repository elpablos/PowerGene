using PowerGene.Core.Helpers;
using System.Collections;
using System.Collections.Generic;

namespace PowerGene.Core.Models.Projects
{
    public class ProjectModel : Dictionary<string, object>, IProjectModel
    {
        public bool IsDeveloper
        {
            get { return (bool?)this["IsDeveloper"] ?? false; }
            set { this["IsDeveloper"] = value; }
        }

        public string Path
        {
            get { return this["Path"] as string; }
            set { this["Path"] = value; }
        }

        public Dictionary<string, object> Metadata
        {
            get { return this.GetDictOrInit("Metadata"); }
            set { this["Metadata"] = value; }
        }

        public Dictionary<string, object> Scripts
        {
            get { return this.GetDictOrInit("Scripts"); }
            set { this["Scripts"] = value; }
        }

        public Dictionary<string, object> ProcessItem
        {
            get { return this.GetDictOrInit("ProcessItem"); }
            set { this["ProcessItem"] = value; }
        }

        public Dictionary<string, object> TempData
        {
            get { return this.GetDictOrInit("TempData"); }
            set { this["TempData"] = value; }
        }

        public ProjectModel()
        {
            ProcessItem = new Dictionary<string, object>();
            IsDeveloper = false;
            Path = null;

            Metadata = new Dictionary<string, object>
            {
                { "ProjectName",  "MyApp" }
            };

            Scripts = new Dictionary<string, object>
            {
                {
                    "InitializeScript",
                    new Dictionary<string, object>
                    {
                        { "Path", "Scripts/Core/Commands/Initialize-Script.ps1" }
                    }
                }
            };
        }

        public Dictionary<string, object> GetDictOrInit(string key)
        {
            if (!this.ContainsKey(key))
            {
                this[key] = new Dictionary<string, object>();
            }
            return this[key] as Dictionary<string, object>;
        }
    }
}

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;
using PowerGene.Core.Helpers;
using PowerGene.Core.Models.Projects;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace PowerGene.Core.Managers.Projects
{
    public partial class ProjectManager : IProjectManager
    {
        private readonly IProjectResolver _projectResolver;

        public IProjectModel Model { get; private set; }

        public ProjectManager(IProjectResolver projectResolver)
        {
            _projectResolver = projectResolver;
            Model = _projectResolver.Model;
        }

        public void Read(string path = null)
        {
            Model = _projectResolver.Model;
            bool isSet = false;
            if (path == null)
            {
                path = Model.Path;
                isSet = true;
            }

            path = FileHelper.GetAbsolutePath(path);

            string projectText = File.ReadAllText(path, Encoding.UTF8);
            Init(Model, projectText);

            if (isSet)
                Model.Path = path;
        }

        public void Save(string path = null)
        {
            Model = _projectResolver.Model;

            if (path == null)
            {
                path = Model.Path;
            }
            else
            {
                Model.Path = path;
            }

            path = FileHelper.GetAbsolutePath(path);

            string json = JsonConvert.SerializeObject(Model, Formatting.Indented);
            File.WriteAllText(path, json, Encoding.UTF8);
        }

        protected void Init(IProjectModel source, string json)
        {
            var project = JsonConvert.DeserializeObject<ProjectModel>(json);

            var prj = source as ProjectModel;
            foreach (var item in project)
            {
                if (item.Value is JToken)
                {
                    prj[item.Key] = (item.Value as JObject).ToObject<Dictionary<string, object>>();
                }
                else
                {
                    prj[item.Key] = item.Value;
                }
        
            }
        }

        public IProjectModel Clone(IProjectModel source = null)
        {
            source = source ?? Model;

            string json = JsonConvert.SerializeObject(source, Formatting.Indented);

            var model = new ProjectModel();
            Init(model, json);

            return model;
        }

        public IProjectModel Clone(Hashtable source)
        {
            string json = JsonConvert.SerializeObject(source, Formatting.Indented);

            var model = new ProjectModel();
            Init(model, json);

            return model;
        }

        public IProjectModel Reload(Hashtable source)
        {
            string json = JsonConvert.SerializeObject(source, Formatting.Indented);
            Init(Model, json);
            return Model;
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PowerGene.Core.Models.Projects;

namespace PowerGene.Module.ItemList.Events
{
    public class ProjectEvent : Core.Events.ProjectEventBase
    {
        public const int ITEMS = 2;

        public ProjectEvent(ProjectModel model, int eventType) : base(model, eventType)
        {
        }
    }
}

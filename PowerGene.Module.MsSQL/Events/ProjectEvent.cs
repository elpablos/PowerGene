using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PowerGene.Core.Models.Projects;

namespace PowerGene.Module.MsSQL.Events
{
    public class ProjectEvent : Core.Events.ProjectEventBase
    {
        public const int TABLES = 2;
        public const int PROCEDURES = 3;
        public const int VIEWS = 4;
        public const int FUNCTIONS = 5;

        public ProjectEvent(ProjectModel model, int eventType) : base(model, eventType)
        {
        }
    }
}

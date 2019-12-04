using PowerGene.Core.Models.Projects;
using System.Collections;
using System.Collections.Generic;

namespace PowerGene.Core.Managers.Projects
{
    public partial interface IProjectManager
    {
        IProjectModel Model { get; }

        void Read(string path = null);
        void Save(string path = null);
        IProjectModel Clone(IProjectModel source = null);
        IProjectModel Clone(Hashtable source);
        IProjectModel Reload(Hashtable source);
    }
}
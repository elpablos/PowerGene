using System.Collections.Generic;

namespace PowerGene.Core.Models.Projects
{
    public interface IProjectModel : IDictionary<string, object>
    {
        bool IsDeveloper { get; set; }
        string Path { get; set; }

        Dictionary<string, object> Metadata { get; set; }
        Dictionary<string, object> Scripts { get; set; }

        Dictionary<string, object> ProcessItem { get; set; }
        Dictionary<string, object> TempData { get; set; }

        Dictionary<string, object> GetDictOrInit(string key);
    }
}

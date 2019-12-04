using PowerGene.App.Models.Shells;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerGene.App.ViewModels.Shells
{
    public interface IShellViewModel
    {
        ShellModel Model { get; }
        void LoadAction(string path = null);
        void RunScript(string script);
    }
}

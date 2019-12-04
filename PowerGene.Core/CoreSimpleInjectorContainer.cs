using Caliburn.Micro;
using PowerGene.Core.Managers.PowerShells;
using PowerGene.Core.Managers.Projects;
using PowerGene.Core.Models.Projects;
using SimpleInjector;
using System.Management.Automation.Runspaces;
using System.Threading;

namespace PowerGene.Core
{
    /// <summary>
    /// Vychozi nastaveni simple injectoru
    /// </summary>
    public static class CoreSimpleInjectorContainer
    {
        /// <summary>
        /// Tvorba spoju mezi interfaci a instancemi
        /// </summary>
        /// <returns></returns>
        public static void Build(Container container)
        {
            // session pro powershell
            var runscape = RunspaceFactory.CreateRunspace();
            runscape.ApartmentState = ApartmentState.STA;
            runscape.Open();

            container.RegisterSingleton<IProjectResolver, ProjectResolver>();
            container.RegisterInstance<Runspace>(runscape);

            container.Register<IProjectManager, ProjectManager>();
            container.Register<IPowerShellManager, PowerShellManager>();
        }
    }
}

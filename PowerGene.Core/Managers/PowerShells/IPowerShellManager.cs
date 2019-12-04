using System;
using System.Management.Automation.Runspaces;

namespace PowerGene.Core.Managers.PowerShells
{
    public interface IPowerShellManager
    {
        Runspace Runspace { get; }

        event EventHandler<string> Message;

        T Run<T>(string scriptPath, object input);
        T RunCommand<T>(string command, object input);
        T RunScript<T>(string script, object input);
        string ReadScript(string scriptPath);
        void SaveScript(string scriptPath, string script);
    }
}
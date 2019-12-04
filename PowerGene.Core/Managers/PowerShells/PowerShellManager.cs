using Caliburn.Micro;
using Newtonsoft.Json;
using PowerGene.Core.Helpers;
using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace PowerGene.Core.Managers.PowerShells
{
    /// <summary>
    /// PowerShell - https://kevinmarquette.github.io/
    /// </summary>
    public class PowerShellManager : IPowerShellManager
    {
        private readonly ILog _logger;

        public event EventHandler<string> Message;

        public Runspace Runspace { get; private set; }

        public PowerShellManager(Runspace runspace)
        {
            Runspace = runspace;
            _logger = LogManager.GetLog(typeof(PowerShellManager));
        }

        public string ReadScript(string scriptPath)
        {
            scriptPath = FileHelper.GetAbsolutePath(scriptPath);
            return System.IO.File.ReadAllText(scriptPath);
        }

        public T Run<T>(string scriptPath, object input)
        {
            // string script = ReadScript(scriptPath);
            string script = $"($dataJson | ConvertFrom-JsonExtend | {scriptPath})";
            return RunCommand<T>(script, input);
        }

        public T RunCommand<T>(string command, object input)
        {
            using (PowerShell instance = PowerShell.Create())
            {
                if (Runspace != null)
                    instance.Runspace = Runspace;
                instance.Streams.Error.DataAdded += Error_DataAdded;
                instance.Streams.Debug.DataAdded += Debug_DataAdded;
                instance.Streams.Information.DataAdded += Information_DataAdded;
                instance.Streams.Progress.DataAdded += Progress_DataAdded;
                instance.Streams.Verbose.DataAdded += Verbose_DataAdded;

                // nastavim promennou $data
                instance.AddCommand("Set-Variable")
                    .AddParameter("Name", "appData")
                    .AddParameter("Value", input)
                    .Invoke();

                string json = string.Empty;
                if (input != null)
                {
                    json = JsonConvert.SerializeObject(input, Formatting.Indented);
                    instance.AddCommand("Set-Variable")
                        .AddParameter("Name", "dataJson")
                        .AddParameter("Value", json)
                        .Invoke();
                }

                // uklidim po sobe
                instance.Commands.Clear();

                // spustim prikaz
                instance.AddScript(command);
                instance.AddParameter("appData", input);
                instance.AddParameter("dataJson", json);

                RaiseMessage(command);

                Collection<PSObject> PSOutput = instance.Invoke();

                foreach (var item in PSOutput)
                {
                    if (item != null)
                        RaiseMessage(item.ToString());
                }
                var first = PSOutput.FirstOrDefault(x => x != null && x.BaseObject.GetType() == typeof(T));
                if (first == null) return default(T);
                return (T)first.BaseObject;
            }
        }

        public T RunScript<T>(string script, object input)
        {
            using (PowerShell instance = PowerShell.Create())
            {
                if (Runspace != null)
                    instance.Runspace = Runspace;
                instance.Streams.Error.DataAdded += Error_DataAdded;
                instance.Streams.Debug.DataAdded += Debug_DataAdded;
                instance.Streams.Information.DataAdded += Information_DataAdded;
                instance.Streams.Progress.DataAdded += Progress_DataAdded;
                instance.Streams.Verbose.DataAdded += Verbose_DataAdded;

                instance.AddScript(script);
                instance.AddParameter("data", input);

                RaiseMessage(script);

                Collection<PSObject> PSOutput = instance.Invoke();

                foreach (var item in PSOutput)
                {
                    RaiseMessage(item.ToString());
                }
                var first = PSOutput.FirstOrDefault(x => x != null && x.BaseObject.GetType() == typeof(T));
                if (first == null) return default(T);
                return (T)first.BaseObject;
            }
        }

        public void SaveScript(string scriptPath, string script)
        {
            if (!System.IO.Path.IsPathRooted(scriptPath))
            {
                scriptPath = System.IO.Path.GetFullPath(scriptPath);
            }

            System.IO.File.WriteAllText(scriptPath, script);
        }

        private void Information_DataAdded(object sender, DataAddedEventArgs e)
        {
            var collection = sender as PSDataCollection<InformationRecord>;
            var info = collection[e.Index];

            RaiseMessage($"INFO: {info}");
        }

        private void Debug_DataAdded(object sender, DataAddedEventArgs e)
        {
            var collection = sender as PSDataCollection<DebugRecord>;
            var debug = collection[e.Index];

            RaiseMessage($"DEBUG: {debug}");
        }

        private void Error_DataAdded(object sender, DataAddedEventArgs e)
        {
            var collection = sender as PSDataCollection<ErrorRecord>;
            var error = collection[e.Index];

            RaiseMessage($"ERROR: {error}");
        }

        private void Verbose_DataAdded(object sender, DataAddedEventArgs e)
        {
            var collection = sender as PSDataCollection<VerboseRecord>;
            var verbose = collection[e.Index];

            RaiseMessage($"VERB: {verbose}");
        }

        private void Progress_DataAdded(object sender, DataAddedEventArgs e)
        {
            var collection = sender as PSDataCollection<ProgressRecord>;
            var progress = collection[e.Index];

            RaiseMessage($"PROGRESS: {progress}");
        }

        private void RaiseMessage(string message)
        {
            Message?.Invoke(this, message);
        }
    }
}

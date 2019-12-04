using System;

namespace PowerGene.Core.Infrastructures.Loggers
{
    /// <summary>
    /// Rozhraní pro logování chyb v systému
    /// </summary>
    public interface ILogger
    {
        void Debug(string message);
        void Trace(string message);
        void Info(string message);
        void Warning(string message);
        void Error(string message);
        void Error(string message, Exception exception);
        void Fatal(string message);
        void Fatal(string message, Exception exception);
    }
}

using PowerGene.Core.Models.Projects;

namespace PowerGene.Core.Events
{
    /// <summary>
    /// Event - změna modelu projektu
    /// </summary>
    public class ProjectEventBase
    {
        /// <summary>
        /// Notifikace celé aplikace
        /// </summary>
        public const int ALL = 0;

        /// <summary>
        /// Notifikace zákl. funkcí
        /// </summary>
        public const int BASE = 1;

        /// <summary>
        /// Model projektu
        /// </summary>
        public IProjectModel Model { get; private set; }

        /// <summary>
        /// Č. typu - použij konstanty! 
        /// <code>ProjectEvent.ALL</code>
        /// </summary>
        public int EventType { get; private set; }

        public ProjectEventBase(IProjectModel model, int eventType)
        {
            EventType = eventType;
            Model = model ?? throw new System.ArgumentNullException(nameof(model));
        }
    }
}

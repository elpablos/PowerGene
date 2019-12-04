namespace PowerGene.Core.Models.Projects
{
    public class ProjectResolver : IProjectResolver
    {
        public IProjectModel Model { get; private set; }

        public ProjectResolver()
        {
            Model = new ProjectModel();
        }
    }
}

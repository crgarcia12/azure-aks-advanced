using demoapp.Models;
using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace demoapp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            string[] fileEntries = Directory.GetFiles("/mnt/demoappfiles");
            
            return View(fileEntries);
        }

        public IActionResult Privacy()
        {
            for(int i = 0; i < 10; i++)
            {
                createFile("/mnt/demoappfiles/file${i}.txt");
            }
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        //Create a method that creates a file in an specific path
        public void createFile(string fullFilePath)
        {
            //Check if the file already exists. If it does, delete it. 
            if (System.IO.File.Exists(fullFilePath))
            {
                System.IO.File.Delete(fullFilePath);
            }

            //Create the file.
            using (StreamWriter outputFile = new StreamWriter(fullFilePath))
            {
                var content = "New file created: ${fullFilePath}";
                outputFile.WriteLine(content);
            }
        }
    }
}
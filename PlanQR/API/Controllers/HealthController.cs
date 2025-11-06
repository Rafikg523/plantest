using Microsoft.AspNetCore.Mvc;

namespace API.Controllers
{
    public class HealthController : BaseApiController
    {
        [HttpGet]
        public IActionResult Get()
        {
            return Ok(new { status = "healthy", timestamp = DateTime.UtcNow });
        }
    }
}

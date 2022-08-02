Html.div(class="container", [
  row([
    cell([
      h5("💜 About the project", id="about")
      p("This app is created and maintained by the <strong><a style='color: black;' href='https://genieframework.com' target='_blank'>Genie</a></strong>
        team as a token of appreciation for the amazing
        work that is being done by the Julia language creators, the Julia package creators, and the Julia users from all around the world.",
        style="padding-bottom: 20px;")

      h5("🎖️ Package downloads badges", id="badges")
      p("Create your own GitHub README badge to display total downloads for your package by using <code>shields.io</code> and our API, ex <br/>
        <code>https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Genie</code><br/>
        <img src='https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Genie' alt='Genie downloads badge' />.")
      p("You can use this Markdown code sample to add the badge to your package's README.md file:<br/>
        <code>[![Genie Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Genie)](https://pkgs.genieframework.com?packages=Genie)</code>.")
      p("In order to customize the badge, you can pass extra arguments to the API request part of the URL, like this: <br/>
        <code>https://pkgs.genieframework.com/api/v1/badge/Genie/label:-sep:,-logo:Fortran-color:blue</code><br/>
        Each element between the <code>-</code> is a separate argument. The first argument is the label (in this example left empty),
        the second is thousands separator (the <code>,</code>), the third is the logo, and the fourth is the color.<br/>
        Check the shields.io documentation for more information about available logos, colors, etc.",
        style="padding-bottom: 20px;")

      h5("🌐 API access", id="api")
      p("You can use the underlying API to integrate this app with your own web application or web service.
        Call:
        <ul>
          <li><code>/api/v1/regions</code> to get the list of regions</li>
          <li><code>/api/v1/packages</code> to get the list of packages</li>
          <li><code>/api/v1/stats</code> to query the download stats,
            ex <br/>
            <code>/api/v1/stats?packages=Genie,Stipple</code><br/>
            <code>/api/v1/stats?regions=eu-central,us-west&packages=Genie,Stipple&startdate=2021-12-30&enddate=2022-01-15</code><br/>
          </li>
        </ul>")
      p("You can also access the Swagger documentation for the API at <a style='color:black' href='/docs' target='_blank'>/docs</a>.
          Many thanks to <a style='color:black' href='https://github.com/jiachengzhang1' target='_blank'>@jiachengzhang1</a> for creating `SwagUI.jl`.")
      p("<strong>Responsible use of the API is mandatory</strong>. We have not added any rate limiting or throttling.
          Please don't abuse the API or you'll ruin it for everybody.",
          style="padding-bottom: 20px;")

      h5("📦 Database download", id="db")
      p("If you want to get a copy of the underlying database, you can download it here:
        <a style='color: black' href='https://www.dropbox.com/s/ogohqe5bo7qfzl2/dev.sqlite?dl=0' target='_blank'>dev.sqlite</a>",
        style="padding-bottom: 20px;")

      h5("💗 How to contribute", id="contribute")
      p("You can contribute to this project by adding or suggesting features, reporting or squashing bugs, or by creating
        issues and making pull requests on
        <a style='color: black;' href='https://github.com/GenieFramework/PkgVizBoard' target='_blank'>GitHub</a>.
        If you enjoy it, share the link and spread the word. ",
        style="padding-bottom: 20px;")

      h5("⭐ Star Genie on Github")
      p("If you enjoy this project please consider starring the
        <a style='color: black;' href='https://github.com/GenieFramework/Genie.jl' target='_blank'>Genie.jl</a> GitHub repo.
        It will help us fund our open source projects.")
    ])
  ])
  row([
    cell([
      footer([
        h6("Powered by <a style='color: black;' href='https://genieframework.com' target='_blank'>Genie</a> | Build interactive data applications in pure Julia")
      ])
    ])
  ])
])
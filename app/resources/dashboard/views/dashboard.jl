Html.div([
heading("Package downloads stats for Julia")
page(
  model, partial = true, [
    row([
      Html.div(class="col-12", [
        select(:searchterms, options = :options, loading = :isprocessing,
                multiple = true, clearable = true, filled = true, counter = true,
                usechips = true, useinput = true, maxvalues = Dashboard.max_search_items, hidebottomspace = true,
                newvaluemode = "add-unique", label = "Search for packages",
                rules = "[val => val && val.length > 0 || 'Please select at least one package']",
                hint = "Type package name then ENTER to search. Repeat to add multiple packages (max 5).",
                filter!! = "filterFn", input__value!! = "setModel"
              )
      ])
    ])

    row([
      expansionitem(expandseparator = true, icon = "tune", label = "Filters",
                    class="col-12", style="padding: 4px;", [
        row([
          Html.div(class="col-12 col-sm-12 col-md-6 col-lg-6 col-xl-6", style="padding: 4px;", [
            select(:filter_regions, options = :regions, multiple = true, clearable = true,
              filled = true, label = "Regions", displayvalue = Dashboard.ALL_REGIONS, usechips = true,
              rules="[val => val && val.length > 0 || 'Please select at least one region']",
              hidebottomspace = true)
          ])

          Html.div(class="col-6 col-sm-6 col-md-3 col-lg-3 col-xl-3", style="padding: 4px;", [
            textfield("Start date", :filter_startdate, clearable = true, filled = true, [
              icon(name = "event", class = "cursor-pointer", style = "height: 100%;", [
                popup_proxy(cover = true, transitionshow = "scale", transitionhide = "scale", [
                  datepicker(:filter_startdate, mask = "YYYY-MM-DD", navmaxyearmonth = "$(Dates.year(now()))/$(Dates.month(now()))")
                ])
              ])
            ])
          ])

          Html.div(class="col-6 col-sm-6 col-md-3 col-lg-3 col-xl-3", style="padding: 4px;", [
            textfield("End date", :filter_enddate, clearable = true, filled = true, [
              icon(name = "event", class = "cursor-pointer", style = "height: 100%", [
                popup_proxy(ref = "qDateProxy", cover = true, transitionshow = "scale", transitionhide="scale", [
                  datepicker(:filter_enddate, mask = "YYYY-MM-DD", navmaxyearmonth = "$(Dates.year(now()))/$(Dates.month(now()))")
                ])
              ])
            ])
          ])
        ])
      ])
    ])

    row([
      cell(class="st-module", [
        h6("Packages downloads over time")

        row([
          section(class="col-12 col-sm-12 col-md-6 col-lg-2", [
            card(flat = true, style="width: 100%", class="st-module", [
              card_section([
                h5(["{{pkg}} {{totals[pkg]}} "], [
                  icon("save_alt", alt = "Downloads")
                ])
                separator()
                card_section([
                  plot("[ { x:(trends[pkg] && trends[pkg][0] ? trends[pkg][0].x : []), y:(trends[pkg] && trends[pkg][0] ? trends[pkg][0].y : []), type:'scatter', name:pkg },
                          { x:(trends[pkg] && trends[pkg][1] ? trends[pkg][1].x : []), y:(trends[pkg] && trends[pkg][1] ? trends[pkg][1].y : []), type:'bar', name:'Downloads' } ]",
                          layout = "{ plot_bgcolor:'transparent', height:100, showlegend:false,
                                      margin: { t:0, b:0, l:0, r:0 },
                                      xaxis: { ticks:'', showline:false, showticklabels:false },
                                      yaxis: { ticks:'', showline:false, showticklabels:false }
                                    }",
                          config = "{ displayModeBar:false }")
                ])
              ])
            ])
          ], @recur("pkg in searchterms.map(p => p.toLowerCase())"))
        ], @iif(:searchterms))

        plot(:data, layout = :layout, config = "{ displayLogo:false, displayModeBar:false }")
      ])
    ])
  ], @iif(:isready)
)
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
        <code>[![Genie Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/Genie)](https://pkgs.genieframework.com?packages=Genie)</code>.",
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
      p("<strong>Responsible use of the API is mandatory</strong>. We have not added any rate limiting or throttling.
          Please don't abuse the API or you'll ruin it for everybody.",
          style="padding-bottom: 20px;")

      h5("📦 Database download", id="db")
      p("If you want to get a copy of the underlying database, you can download it here:
        <a style='color: black' href='https://www.dropbox.com/s/3h48n0xk3gc2x1y/dev.sqlite?dl=0' target='_blank'>dev.sqlite</a>",
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
])
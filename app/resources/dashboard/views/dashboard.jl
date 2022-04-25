Html.div([
heading("Package downloads stats for Julia")
page(
  model, partial = true, [
    row([
      Html.div(class="col-12", [
        select(:searchterms, options = :packages, loading = :isprocessing, readonly = :isprocessing,
                multiple = true, clearable = true, filled = true, counter = true,
                usechips = true, useinput = true, maxvalues = Dashboard.max_search_items, hidebottomspace = true,
                newvaluemode = "add-unique", label = "Search for packages",
                rules = "[val => val && val.length > 0 || 'Please select at least one package']",
                hint = "Type package name then ENTER to search. Repeat to add multiple packages (max $(Dashboard.max_search_items)).")
      ])
    ])

    row([
      expansionitem(expandseparator = true, icon = "tune", label = "Filters", hidebottomspace = true,
                    class="col-12", style="padding: 4px;", [
        row([
          Html.div(class="col-12 col-sm-12 col-md-6 col-lg-6 col-xl-6", style="padding: 4px;", [
            select(:filter_regions, options = :regions, multiple = true, clearable = true,
              filled = true, label = "Regions", displayvalue = PkgVizBoard.ALL_REGIONS, usechips = true,
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
        h5("Packages downloads over time", style="display: block", [
          btngroup(dense = true, class="float-right", [
              btn("View by", color = "primary", flat = true, ripple = false, nocaps = true, dense = true)
              btndropdown(color = "primary", dense = true, [
                list([
                  item([
                    btn(PkgVizBoard.DAY, outline! = "interval == '$(PkgVizBoard.DAY)'",
                        icon = "calendar_month", label = "Day", class = "cursor-pointer", nocaps = true,
                        @click("interval = \"$(PkgVizBoard.DAY)\""))
                  ])
                  item([
                    btn(PkgVizBoard.MONTH, outline! = "interval == '$(PkgVizBoard.MONTH)'",
                        icon = "date_range", label = "Month", class = "cursor-pointer", nocaps = true,
                        @click("interval = \"$(PkgVizBoard.MONTH)\""))
                  ])
                  item([
                    btn(PkgVizBoard.YEAR, flat! = "interval != '$(PkgVizBoard.YEAR)'",
                        icon = "event", label = "Year", class = "cursor-pointer", nocaps = true,
                        @click("interval = \"$(PkgVizBoard.YEAR)\""))
                  ])
                ])
              ])
            ])
        ])

        row([
          section(class="col-12 col-sm-12 col-md-6 col-lg-2", [
            card(flat = true, style="width: 100%", class="st-module", [
              card_section([
                h5(["{{pkg}} {{totals[pkg]}} "])
                separator()
                card_section([
                  plot("[ { x:(trends[pkg] && trends[pkg][0] ? trends[pkg][0].x : []), y:(trends[pkg] && trends[pkg][0] ? trends[pkg][0].y : []), type:'scatter', name:pkg },
                          { x:(trends[pkg] && trends[pkg][1] ? trends[pkg][1].x : []), y:(trends[pkg] && trends[pkg][1] ? trends[pkg][1].y : []), type:'bar', name:'Downloads' } ]",
                          layout = "{ plot_bgcolor:'transparent', height:75, showlegend:false,
                                      margin: { t:0, b:0, l:40, r:0 },
                                      xaxis: { ticks:'', showline:false, showticklabels:false },
                                      yaxis: {  }
                                    }",
                          config = "{ displayModeBar:false }")
                ])
              ])
            ], @iif("totals[pkg]"))
          ], @recur("pkg in searchterms.map(p => p.toLowerCase())"), key! = "pkg")
        ], @iif(:searchterms))

        plot(:data, layout = :layout, config = "{ displayLogo:false, displayModeBar:false }")
      ], @iif("searchterms.length > 0"))
    ])
  ], @iif(:isready)
)
partial(joinpath(Genie.config.path_resources, "dashboard", "views", "help.jl"), context = context)
])
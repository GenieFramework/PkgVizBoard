page(
  model, partial = true, [
    heading("PkgStats - Package downloads stats for Julia")

    row([
      Html.div(class="col-12", [
        select(:searchterms, options = :packages, loading = :isprocessing,
                multiple = true, clearable = true, filled = true, counter = true,
                usechips = true, useinput = true, maxvalues = 5, hidebottomspace = true,
                newvaluemode = "add-unique", label = "Search for packages",
                rules = "[val => val && val.length > 0 || 'Please select at least one package']",
                hint = "Type package name then ENTER to search. Repeat to add multiple packages (max 5).")
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
          cell(style = "padding: 4px;", [
            chip("", nothing, ["{{pkg}}: {{totals[pkg]}}"], size = "md", square = true, style = "width: 100%; ")
          ], @recur(:"pkg in searchterms"))
        ], @iif(:searchterms))

        plot(:data, layout = :layout, config = "{ displaylogo: false }")
      ])
    ])

    row([
      footer([
        h6("Powered by Stipple")
      ])
    ])
  ], @iif(:isready)
)
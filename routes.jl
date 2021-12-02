using Genie, Stipple, StippleUI, StipplePlotly
import Dates

#=== config ==#

for m in [Genie, Stipple, StippleUI, StipplePlotly]
  m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
end

# WEB_TRANSPORT = Genie.WebChannels #Genie.WebThreads #

#== data ==#

function plotdata(name)
  PlotData(
    x = ["Jan2019", "Feb2019", "Mar2019", "Apr2019", "May2019",
          "Jun2019", "Jul2019", "Aug2019", "Sep2019", "Oct2019",
          "Nov2019", "Dec2019"],
    y = Int[rand(1:100_000) for x in 1:12],
    plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = name
  )
end

#== reactive model ==#

Base.@kwdef mutable struct Model <: ReactiveModel
  # filter UI
  searchterms::R{Vector{String}} = String[]

  filter_startdate::R{Date} = Dates.today() - Dates.Year(1)
  filter_enddate::R{Date} = Dates.today()

  regions::Vector{String} = String["Europe", "Asia", "North America", "South America", "Australia"]
  filter_regions::R{Vector{String}} = String[]

  # plot
  data::R{Vector{PlotData}} = [plotdata("Genie"), plotdata("Makie"), plotdata("Flux")]
  layout::R{PlotLayout} = PlotLayout(
      plot_bgcolor = "#fff",
      title = PlotLayoutTitle(text="Package downloads", font=Font(24))
    )
  config::R{PlotConfig} = PlotConfig()
end

#== handlers ==#

function handlers(model)
  on(model.searchterms) do val
    @show val
  end
  on(model.filter_startdate) do val
    @show val
  end
  on(model.filter_enddate) do val
    @show val
  end
  on(model.filter_regions) do val
    @show val
  end
end

#== ui ==#

function ui(model)
  page(
    prepend = """
    <style>
      .rb {
        border-right: 10pt solid #fff;
      }
    </style>
    """,

    vm(model), class="container", [
      heading("PkgStats")

      row([
        cell(class="st-module", [

          row([
            cell([
              textfield("Search for your favourite packages", :searchterms, clearable = true, filled = true)
            ])
          ])

          row([

            cell(class="rb", [
              textfield("Start date", :filter_startdate, clearable = true, filled = true, [
                icon(name="event", class="cursor-pointer", [
                  popup_proxy(cover = true, transitionshow="scale", transitionhide="scale", [
                    datepicker(:filter_startdate, mask = "YYYY-MM-DD")
                  ])
                ])
              ])
            ])

            cell(class="rb", [
              textfield("End date", :filter_enddate, clearable = true, filled = true, [
                icon(name="event", class="cursor-pointer", [
                  popup_proxy(ref="qDateProxy", cover = true, transitionshow="scale", transitionhide="scale", [
                    datepicker(:filter_enddate, mask = "YYYY-MM-DD")
                  ])
                ])
              ])
            ])

            cell([
              select(:filter_regions, options = :regions, multiple = true, clearable = true, filled = true, label = "Region")
            ])
          ])
        ])
      ])

      row([
        cell(class="st-module", [
          h6("Packages downloads over time")
          plot(:data, layout = :layout, config = :config)
        ])
      ])

      row([
        footer([
          h6("Powered by Stipple")
        ])
      ])
    ]
  )
end

#== server ==#

route("/") do
  model = Stipple.init(Model())
  handlers(model)

  html(ui(model), context = @__MODULE__)
end

isrunning(:webserver) || up()
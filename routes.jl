using Genie, Stipple, StippleUI, StipplePlotly
import Dates

using StatsController

#=== config ==#

for m in [Genie, Stipple, StippleUI, StipplePlotly]
  m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
end

# WEB_TRANSPORT = Genie.WebChannels #Genie.WebThreads #

#== data ==#


# x should be 


function plotdata(data::Vector)
  @info "data is: " data[1].package_name
  # start date - end date 
  # should go in x
  # daily downloads request_count

  # create a array of dictionary julia
  # each dictionary should have a String and Int
  

  for d in data
    d
    

  PlotData(
    x = ["Sep2021", "Oct2021", "Nov2021"],
    y = Int[rand(1:100_000) for x in 1:12],  # sum for month of sep, sum for month of october
    plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = data[1].package_name
  )
end

function plotdata(name::String)
  PlotData(
    x = ["Sep2021", "Oct2021", "Nov2021"],
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

  regions::Vector{String} = String["au","cn-east","cn-northeast","cn-southeast","eu-central","in","kr","sa","sg","us-east","us-west"]
  filter_regions::R{Vector{String}} = String[]

  # plot
  data::R{Vector{PlotData}} = [plotdata("Genie")]
  #data::R{Vector{PlotData}} = PlotData[]

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
    data = StatsController.search_by_package_name(val[1])
    #model.data = [plotdata(data)]

    @info model.data = [plotdata(data)]

    @info data[1].package_name

    @info "First Element" first(data)
    @info "Last Element" last(data)
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

  onany(model.searchterms, model.filter_regions, model.filter_startdate, model.filter_enddate) do name, region, start_date, end_date
    @show name, region, start_date, end_date
    # (name, region, start_date, end_date) = (["Genie"], ["cn-east", "cn-northeast"], Date("2020-12-24"), Date("2021-12-16"))

    objs = StatsController.search(name[1], region[1], start_date, end_date)
    
    plotdata(objs)

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
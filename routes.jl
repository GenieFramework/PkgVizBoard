using Genie, Stipple, StippleUI, StipplePlotly
import Dates

using StatsController

#=== config ==#

for m in [Genie, Stipple, StippleUI, StipplePlotly]
  m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
end

#WEB_TRANSPORT = Genie.WebChannels #Genie.WebThreads #

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


function plotdata(r_stats, pkg_names)

  all_stats = Dict[]
  for pkg_name in pkg_names

    xy_val = Dict{Date, Int}()

    for r_stat in r_stats                                                 # n^2 complexity clean it
      if r_stat.package_name == pkg_name
        if haskey(xy_val, r_stat.date)
          xy_val[r_stat.date] = xy_val[r_stat.date] + r_stat.request_count
        else
          xy_val[r_stat.date] = r_stat.request_count
        end
      end
    end
    push!(all_stats, xy_val)
  end


  my_data = PlotData[]

  for (pkg_name, all_stat) in zip(pkg_names, all_stats)

    new_stat = sort(all_stat)
    @info typeof(new_stat)

    x_val = String[]
    for key in keys(new_stat)                                             # n^2 complexity clean it
      push!(x_val, Dates.format(key, "yyyy-mm-dd"))
    end

    y_val = Int64[]

    for val in values(new_stat)
      push!(y_val, val)
    end

    @info "😋😋😋" x_val
    @info "😋😋😋" y_val
    @info typeof(x_val), typeof(y_val)
    @info size(x_val), size(y_val)

    @info push!(my_data, PlotData(
      x = x_val,
      y = y_val,
      plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
      name = pkg_name
    ))
  end
  
  @show "👍👍👍👍👍👍👍👍👍👍👍👍👍👍👍" my_data
  @show "👍👍👍👍👍👍👍👍👍👍👍👍👍👍👍" typeof(my_data)

  return my_data
end

#== reactive model ==#

Base.@kwdef mutable struct Model <: ReactiveModel
  # filter UI
  searchterms::R{Vector{String}} = String[]

  filter_startdate::R{Date} = Dates.today() - Dates.Month(3)
  filter_enddate::R{Date} = Dates.today() - Dates.Month(1)

  regions::Vector{String} = String["au","cn-east","cn-northeast","cn-southeast","eu-central","in","kr","sa","sg","us-east","us-west"]
  filter_regions::R{Vector{String}} = String["in"]

  # data for plot
  data::R{Vector{PlotData}} = [plotdata("Genie")]

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

  onany(model.searchterms, model.filter_regions, model.filter_startdate, model.filter_enddate) do pkg_names, regions, start_date, end_date
    result_stats = StatsController.search(pkg_names, regions, start_date, end_date)
    model.data[] = plotdata(result_stats, pkg_names)
    #@info model.data = [plotdata("Stipple"), plotdata("Genie")]
    @show model.data
    @show model.regions
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

            cell([
              btn(color = "primary", label = "Search", @click("process = true"))
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
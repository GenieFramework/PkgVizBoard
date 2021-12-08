using Genie, Stipple, StippleUI, StipplePlotly
import Dates, OrderedCollections

using StatsController

#=== config ==#

for m in [Genie, Stipple, StippleUI, StipplePlotly]
  m.assets_config.host = "https://cdn.statically.io/gh/GenieFramework"
end

#== plot data logic ==#

function plotcomponent(x_val, y_val, name)
  PlotData(
    x = x_val,
    y = y_val,
    plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER,
    name = name
  )
end

function insert_plot_data(r_stats)
  
  stats = Dict{String, Dict{Date, Int64}}()

  for r_stat in r_stats
    haskey(stats, r_stat.package_name) || (stats[r_stat.package_name] = Dict{Date, Int}())
    current_pkg_stats = stats[r_stat.package_name]
    if haskey(current_pkg_stats, r_stat.date)
      current_pkg_stats[r_stat.date] += r_stat.request_count
    else
      current_pkg_stats[r_stat.date] = r_stat.request_count
    end
    stats[r_stat.package_name] = current_pkg_stats
  end

  plot_component_data::Vector{PlotData} = PlotData[]

  for (pkg_name, pkg_data) in stats
    @info typeof(pkg_data)
    x_val, y_val = String[], Int64[]
    sorted_pkg_data = sort(pkg_data)

    for(download_date, req_count) in sorted_pkg_data
      push!(x_val, Dates.format(download_date, "yyyy-mm-dd"))
      push!(y_val, req_count)
    end

    push!(plot_component_data, plotcomponent(x_val, y_val, pkg_name))
  end
  
  return plot_component_data
end

#== reactive model ==#

Base.@kwdef mutable struct Model <: ReactiveModel
  db_lookup::R{Bool} = false
  process::R{Bool} = false
  # filter UI
  searchterms::R{Vector{String}} = String[]

  filter_startdate::R{Date} = Dates.today() - Dates.Month(3)
  filter_enddate::R{Date} = Dates.today() - Dates.Month(1)

  regions::Vector{String} = String["all", "au","cn-east","cn-northeast","cn-southeast","eu-central","in","kr","sa","sg","us-east","us-west"]
  filter_regions::R{Vector{String}} = String["all"]

  # data for plot
  data::R{Vector{PlotData}} = []

  layout::R{PlotLayout} = PlotLayout(
      plot_bgcolor = "#fff",
      title = PlotLayoutTitle(text="Package downloads", font=Font(24))
    )
  config::R{PlotConfig} = PlotConfig()
end

#== handlers ==#

function handlers(model)
  on(model.searchterms) do searchitems   
    @show searchitems
  end
  on(model.filter_startdate) do startdate
    @show startdate
  end
  on(model.filter_enddate) do enddate
    @show enddate
  end
  on(model.filter_regions) do areas
    @show areas
  end
  on(model.process) do _
    if model.process[]
      model.process[] = false
      @info "Calculating..."
      if size(model.searchterms[]) > (0,) && size(model.filter_regions[]) > (0,) && !model.db_lookup[] 
        @info "Inner Loop running..."
        @info model.filter_startdate[]
        model.db_lookup[] = true
        pkgnames::Vector{String} = split((model.searchterms)[1], ", ")
        result_stats = StatsController.search(pkgnames, model.filter_regions[], model.filter_startdate[], model.filter_enddate[])
        model.data[] = insert_plot_data(result_stats)
        model.db_lookup[] = false
      end
    end
  end
end

#== ui ==#

function ui(model)
  page(
    prepend = """
    <style>
      .rb {
        border-right: 10pt solid #fff;
      },
      .q-mt-md {
        margin-left: 50px;
      }
    </style>
    """,

    vm(model), class="container", [
      heading("PkgStats")

      row([
        cell(class="st-module", [

          row([
            cell([
              textfield("Search for your favourite packages (Hit enter to search)", :searchterms, clearable = true, filled = true)
            ])
          ])

          row([

            cell(class="rb", [
              textfield("Start date", :filter_startdate, clearable = true, filled = true, [
                icon(name="event", class="cursor-pointer", [
                  popup_proxy(cover = true, transitionshow="scale", transition__hide="scale", [
                    datepicker(:filter_startdate, mask = "YYYY-MM-DD", navigation__min__year__month="2021/09", navigation__max__year__month="2021/12")
                  ])
                ])
              ])
            ])

            cell(class="rb", [
              textfield("End date", :filter_enddate, clearable = true, filled = true, [
                icon(name="event", class="cursor-pointer", [
                  popup_proxy(ref="qDateProxy", cover = true, transitionshow="scale", transitionhide="scale", [
                    datepicker(:filter_enddate, mask = "YYYY-MM-DD", navigation__min__year__month="2021/09")
                  ])
                ])
              ])
            ])

            cell([
              select(:filter_regions, options = :regions, multiple = true, clearable = true,
               filled = true, label = "Region", display__value = "all", use__chips = true,
               rules="[ val => val && val.length > 0 || 'Please select atleast one region']")
            ])

            cell([
              btn("Visualize", type = "submit", loading = :submitting, class = "q-mt-md", color = "teal", @click("process = true"), [
                template("", "v-slot:loading", [
                  spinner(:facebook, wrap = StippleUI.NO_WRAPPER)
                  ])
              ])
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
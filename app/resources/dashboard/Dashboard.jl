module Dashboard

using Stipple, StipplePlotly
using Dates, Stats
using SearchLight, SearchLightSQLite
using Packages
using OrderedCollections
using DataFrames, GLM

const max_search_items = 6

function stats(r_stats)
  stats = OrderedDict{String,OrderedDict{Date,Int}}()

  for r_stat in r_stats
    haskey(stats, r_stat.package_name) || (stats[r_stat.package_name] = Dict{Date,Int}())
    current_pkg_stats = stats[r_stat.package_name]

    if haskey(current_pkg_stats, r_stat.date)
      current_pkg_stats[r_stat.date] += r_stat.request_count
    else
      current_pkg_stats[r_stat.date] = r_stat.request_count
    end

    stats[r_stat.package_name] = current_pkg_stats
  end

  stats
end


function StipplePlotly.Charts.PlotData(name, data)
  PlotData( y = lm(@formula(y ~ x), DataFrame(y = data, x = 1:length(data))) |> predict,
            x = 1:length(data),
            name = name,
            plot = StipplePlotly.Charts.PLOT_TYPE_LINE)
end


function computestats(r_stats, model)
  data = typeof(model.data[])()
  totals = typeof(model.totals[])()
  trends = typeof(model.trends[])()

  for (pkg_name, pkg_data) in stats(r_stats)
    x_val, y_val = String[], Int64[]
    for(download_date, req_count) in pkg_data
      push!(x_val, Dates.format(download_date, "yyyy-mm-dd"))
      push!(y_val, req_count)
    end

    vals = pkg_data |> values |> collect

    push!(data, PlotData(x = x_val, y = y_val, name = pkg_name, plot = StipplePlotly.Charts.PLOT_TYPE_SCATTER))
    totals[lowercase(pkg_name)] = sum(vals |> collect)
    trends[lowercase(pkg_name)] = [PlotData(pkg_name, vals),
                        PlotData(x = 1:length(vals), y = vals, name = pkg_name, plot = StipplePlotly.Charts.PLOT_TYPE_LINE)]
  end

  data, totals, trends
end

#== handlers ==#

function handlers(model)
  # triggered when the search form is submitted
  # computes the stets for the requested parameters
  # and renders the results
  on(model.isprocessing) do val
    val || return

    if isempty(model.searchterms[]) || isempty(model.filter_regions[])
      model.isprocessing[] = false

      return
    end

    if length(model.searchterms[]) > max_search_items
      model.searchterms[] = model.searchterms[1:max_search_items]

      return
    end

    model.data[], model.totals[], model.trends[] = computestats(Stats.search(model), model)

    model.isprocessing[] = false
  end

  # triggered when package names are typed
  # if at least 3 letters typed, we search for matching packages
  # and show them as options in the drop down
  on(model.searchterms) do val
    ! isempty(val) && (model.isprocessing[] = true)
  end

  onany(model.filter_startdate, model.filter_enddate, model.filter_regions) do st, ed, reg
    isempty(reg) && (model.filter_regions[] = [ALL_REGIONS])
    length(reg) > 1 && in(ALL_REGIONS, reg) && (model.filter_regions[] = filter(x->x!=ALL_REGIONS, reg))

    model.isprocessing[] = true
  end

  on(model.isready) do val
  end

  model
end

#== reactive model ==#

const ALL_REGIONS = "all"
const REGIONS = String[ALL_REGIONS, "au", "cn-east", "cn-northeast", "cn-southeast", "eu-central", "in", "kr", "sa", "sg", "us-east", "us-west"]

export Model

@reactive mutable struct Model <: ReactiveModel
  # filter UI
  searchterms::R{Vector{String}} = String[]
  packages::Vector{String} = ["Genie", "Stipple"] #[p.name for p in all(Package, SQLQuery(order = "name ASC"))]

  filter_startdate::R{Date} = Dates.today() - Dates.Month(3)
  filter_enddate::R{Date} = Dates.today() - Dates.Day(1)

  regions::Vector{String} = REGIONS
  filter_regions::R{Vector{String}} = String[ALL_REGIONS]

  # data for plot
  data::R{Vector{PlotData}} = []
  layout::R{PlotLayout} = PlotLayout(plot_bgcolor = "#fff")

  # downloads totals
  totals::R{Dict{String,Int}} = Dict{String,Int}()

  # trendlines
  trends::R{Dict{String,Vector{PlotData}}} = Dict{String,Vector{PlotData}}()
end

Stipple.js_methods(::Model) = raw"""
  filterFn (val, update, abort) {
    update(() => {
      const needle = val.toLowerCase()
      this.packages = ["Genie", "Stipple"].filter(v => v.toLowerCase().indexOf(needle) > -1)
    })
  }
"""

function factory()
  model = Model |> init |> handlers
end


end
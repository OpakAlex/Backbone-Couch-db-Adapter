@BackBoneCouchPaginationCollection =
  total_items: false
  _current_page: 1
  per_page: @.__proto__.limit
  all_models: []

  itemsPerPage: (itemsPerPage) ->
    if (typeof itemsPerPage != 'undefined' )
      @aitemsPerPage = itemsPerPage
    this.itemsPerPage

  currentPage: () ->
    @_current_page

  loadPage: (page,save) ->
    @all_models = _.union(@all_models, @models) if save
    if page
      @_current_page = page
    @fetch()

  nextPage: ->
    _nextPage = @currentPage() + 1
    @.__proto__.skip  = @currentPage() * @.__proto__.limit
    @loadPage _nextPage, true

  previousPage: ->
    @.__proto__.skip  = parseInt(@.__proto__.skip / this.currentPage()) #+ @.__proto__.limit
    if @.__proto__.skip >= 0
      @loadPage this.currentPage() - 1, false

  paginationInfo: ->
    result =
      totalItems: @totalItems
      totalPages: (if (@totalItems) then (Math.ceil(@totalItems / @itemsPerPage())) else false)
      itemsPerPage: @itemsPerPage()
      currentPage: @currentPage()
      previousPage: false
      nextPage: false
    result.previousPage = result.currentPage - 1  if result.currentPage > 1
    result.nextPage = result.currentPage + 1  if (result.currentPage < result.totalPages) and (result.totalPages > 1)
    result


#  actAs_Paginatable_currentPage_attr: 'page',
#  actAs_Paginatable_itemsPerPage_attr: 'itemsPerPage',
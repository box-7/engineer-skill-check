module EmployeesHelper
  def sort_order(column, title)
    direction = params[:direction] == 'desc' ? 'asc' : 'desc'
    link_to title, { sort: column, direction: direction }, class:"userList"
  end
end

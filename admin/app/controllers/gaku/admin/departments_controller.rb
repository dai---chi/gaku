module Gaku
  class Admin::DepartmentsController < Admin::BaseController

    respond_to :js,   only: %i( new create edit update destroy index )

    before_action :set_department, only: %i( edit update destroy )

    def index
      @departments = Department.all
      set_count
      respond_with @departments
    end

    def new
      @department = Department.new
      respond_with @department
    end

    def create
      @department = Department.new(department_params)
      @department.save
      set_count
      respond_with @department
    end

    def edit
    end

    def update
      @department.update(department_params)
      respond_with @department
    end

    def destroy
      @department.destroy
      set_count
      respond_with @department
    end

    private

    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:name)
    end

    def set_count
      @count = Department.count
    end

  end
end

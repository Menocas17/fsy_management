# Categorías de gasto: se agregan cuando hacen falta, con su icono y color y, si se quiere, presupuesto propio.
class ExpenseCategoriesController < ApplicationController
  before_action :require_finance_configurator!
  before_action :set_category, only: %i[edit update destroy]

  def new
    @category = ExpenseCategory.new(icon: "wallet", color: "primary")
  end

  def create
    @category = ExpenseCategory.new(category_params)
    if @category.save
      record_audit!(category: :finanzas, action: "created", target: @category, summary: "Agregó la categoría «#{@category.name}»")
      redirect_to edit_finances_path, notice: "Categoría agregada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      record_audit!(category: :finanzas, action: "updated", target: @category, summary: "Editó la categoría «#{@category.name}»")
      redirect_to edit_finances_path, notice: "Categoría guardada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Solo si no tiene gastos: los gastos ya registrados no pueden quedar sin su categoría.
  def destroy
    if @category.destroy
      record_audit!(category: :finanzas, action: "deleted", target: @category, summary: "Borró la categoría «#{@category.name}»")
      redirect_to edit_finances_path, notice: "Categoría borrada."
    else
      redirect_to edit_finances_path, alert: "«#{@category.name}» ya tiene gastos: no se puede borrar."
    end
  end

  private
    def set_category
      @category = ExpenseCategory.find(params[:id])
    end

    def category_params
      permitted = params.expect(expense_category: [ :name, :budget, :icon, :color ])
      permitted[:budget_cents] = Money.parse(permitted.delete(:budget))
      permitted
    end
end

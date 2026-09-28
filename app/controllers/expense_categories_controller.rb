# Categorías de gasto: se agregan cuando hacen falta y, si se quiere, con presupuesto propio.
class ExpenseCategoriesController < ApplicationController
  before_action :require_finance_configurator!

  def create
    category = ExpenseCategory.new(name: params[:name], budget_cents: Money.parse(params[:budget]))
    if category.save
      record_audit!(category: :finanzas, action: "created", target: category, summary: "Agregó la categoría «#{category.name}»")
      redirect_to edit_finances_path, notice: "Categoría agregada."
    else
      redirect_to edit_finances_path, alert: category.errors.full_messages.to_sentence
    end
  end

  def update
    category = ExpenseCategory.find(params[:id])
    if category.update(name: params[:name], budget_cents: Money.parse(params[:budget]))
      record_audit!(category: :finanzas, action: "updated", target: category, summary: "Editó la categoría «#{category.name}»")
      redirect_to edit_finances_path, notice: "Categoría guardada."
    else
      redirect_to edit_finances_path, alert: category.errors.full_messages.to_sentence
    end
  end

  # Solo si no tiene gastos: los gastos ya registrados no pueden quedar sin su categoría.
  def destroy
    category = ExpenseCategory.find(params[:id])
    if category.destroy
      record_audit!(category: :finanzas, action: "deleted", target: category, summary: "Borró la categoría «#{category.name}»")
      redirect_to edit_finances_path, notice: "Categoría borrada."
    else
      redirect_to edit_finances_path, alert: "«#{category.name}» ya tiene gastos: no se puede borrar."
    end
  end
end

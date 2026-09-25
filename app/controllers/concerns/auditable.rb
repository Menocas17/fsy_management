module Auditable
  extend ActiveSupport::Concern

  private
    def record_audit!(category:, action:, target:, summary:)
      actor = Current.user&.participant

      AuditLog.create!(
        actor: actor,
        actor_name: actor&.full_name || "Administrador del sistema",
        action: action,
        category: category,
        summary: summary,
        target_type: target&.class&.name,
        target_id: target&.id,
        target_name: target_name_for(target)
      )
    end

    # Una carga masiva no apunta a un solo registro: la entrada queda sin objetivo.
    def target_name_for(target)
      return nil if target.nil?

      target.respond_to?(:full_name) ? target.full_name : target.name
    end

    def changed_field_labels(record, labels)
      labels.filter_map { |key, label| label if record.saved_changes.key?(key) }.uniq
    end

    def spanish_list(words)
      words.to_sentence(words_connector: ", ", two_words_connector: " y ", last_word_connector: " y ")
    end
end

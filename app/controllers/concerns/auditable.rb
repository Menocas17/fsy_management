module Auditable
  extend ActiveSupport::Concern

  private
    def record_audit!(category:, action:, target:, summary:)
      # En «Ver como» lo hizo el superadmin, no la persona cuya vista estaba usando.
      actor = Current.real_user&.participant
      actor_name = actor&.full_name || "Administrador del sistema"
      actor_name += " (viendo como #{Current.user.full_name})" if Current.viewing_as?

      AuditLog.create!(
        actor: actor,
        actor_name: actor_name,
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

    # Solo lo que de verdad cambió. Un formulario guardado sin tocar manda "" donde había nil, y en las
    # columnas jsonb agrega llaves vacías: Rails lo ve como cambio y el historial decía «Actualizó contacto
    # y notas» sin que nadie cambiara nada. Un valor de labels puede ser un Hash para una columna jsonb
    # (llave → etiqueta), y entonces nombra lo que cambió adentro («teléfono», «alergias»).
    def changed_field_labels(record, labels)
      labels.flat_map { |column, label|
        before, after = record.saved_changes[column]
        next [] unless record.saved_changes.key?(column)

        if label.is_a?(Hash)
          before, after = audit_hash(before), audit_hash(after)
          (before.keys | after.keys).filter_map { |key| label.fetch(key, nil) if before[key] != after[key] }
        else
          audit_value(before) == audit_value(after) ? [] : [ label ]
        end
      }.uniq
    end

    def audit_value(value)
      value.is_a?(String) ? value.strip.presence : value
    end

    def audit_hash(value)
      value.to_h.transform_values { |item| audit_value(item) }.compact_blank
    end

    def spanish_list(words)
      words.to_sentence(words_connector: ", ", two_words_connector: " y ", last_word_connector: " y ")
    end
end

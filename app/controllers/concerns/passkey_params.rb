# Lo que el navegador manda de una passkey (navigator.credentials.create/get, pasado a base64url por
# passkey_controller.js): solo las llaves que WebAuthn necesita.
module PasskeyParams
  extend ActiveSupport::Concern

  private
    def credential_params
      params.require(:credential).permit(:type, :id, :rawId, :authenticatorAttachment,
        response: [ :attestationObject, :clientDataJSON, :authenticatorData, :signature, :userHandle, { transports: [] } ],
        clientExtensionResults: {}).to_h
    end

    def relying_party
      @relying_party ||= Passkey.relying_party(request)
    end
end

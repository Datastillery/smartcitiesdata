defmodule Andi.Test.AuthHelper do
  @moduledoc """
  Helper functions and valid values for testing auth things.
  """
  alias AndiWeb.Auth.TokenHandler

  def build_authorized_conn() do
    default_opts = [
      store: :cookie,
      key: "secretkey",
      encryption_salt: "encrypted cookie salt",
      signing_salt: "signing salt"
    ]

    signing_opts = Plug.Session.init(Keyword.put(default_opts, :encrypt, false))

    really_far_in_the_future = 3_000_000_000_000

    config = [
      allowed_algos: ["RS256"],
      issuer: "https://smartcolumbusos-demo.auth0.com/",
      secret_fetcher: Auth.Auth0.SecretFetcher,
      verify_issuer: true,
      allowed_drift: really_far_in_the_future
    ]

    Application.put_env(:andi, TokenHandler, config)

    jwt = valid_jwt()
    conn =
      Phoenix.ConnTest.build_conn()
      |> Map.put(:secret_key_base, "H6YQQ2WrncgGPFvRVraAEAH2GqdUSCGTMklHHKNnOEXtBd9ugvFYo/ZDJH+5vKKj")
      |> Plug.Session.call(signing_opts)
      |> Plug.Conn.fetch_session()
      |> TokenHandler.put_session_token(jwt)
      |> Guardian.Plug.VerifySession.call(module: TokenHandler, error_handler: AndiWeb.Auth.ErrorHandler, claims: %{})

    conn
  end

  def valid_jwt() do
    "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik9ESXlSRU5ETkVZelFrVkVNakF5TnpFNFJUTkNNVE0yUVROR1JqVTJOVVUzUXpaRFFVUTFPUSJ9.eyJodHRwczovL2FuZGkuc21hcnRjb2x1bWJ1c29zLmNvbS9yb2xlcyI6WyJDdXJhdG9yIl0sImlzcyI6Imh0dHBzOi8vc21hcnRjb2x1bWJ1c29zLWRlbW8uYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDVlMzA2NmRhZjA0OGFhMGU3MWJkZDc3ZSIsImF1ZCI6WyJhbmRpIiwiaHR0cHM6Ly9zbWFydGNvbHVtYnVzb3MtZGVtby5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNjAxNTc1NTQyLCJleHAiOjE2MDE2NjE5NDIsImF6cCI6IktyQTk5cWdVRHdSV3ZiSTA3WU9rbklaU1MxanpkWFVyIiwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsInBlcm1pc3Npb25zIjpbInJlYWQ6ZGF0YXNldHMiLCJyZWFkOm9yZ2FuaXphdGlvbnMiLCJ3cml0ZTpkYXRhc2V0cyIsIndyaXRlOm9yZ2FuaXphdGlvbnMiXX0.cM_U-U1KhFzxOApg9ePj2htwb-Osp3hskF1yppWNj3FbWn3RdQp_ib0TehToVPiE3VGe9Z2vQNV1Es5O-3zNwTm23myfw1e6w1TQIIip8IAmJKG9SXAuK5I4dc1F8mlSZmSwY9KpuslHWTydzR2gjA2n4h0wCXYAd2HUDMWWZfOEgDZiuYjW14c4PEnoSC4tNbKLiObUBrFPP-yggiTjENiJ1p6ZWPBbgoDfqewAgiZqt7cXoh5n3Na46dFPqUlespmAyYDH9QdMlvKXF9FWWUSQnkoNucZ3DwTpwHgAwze3AJJj-Q7VmwKdzpdGSeGXN_DieJzI612Zd_h__ao_Vg"
  end

  def valid_jwt_unauthorized_roles() do
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Ik9ESXlSRU5ETkVZelFrVkVNakF5TnpFNFJUTkNNVE0yUVROR1JqVTJOVVUzUXpaRFFVUTFPUSJ9.eyJpc3MiOiJodHRwczovL3NtYXJ0Y29sdW1idXNvcy1kZW1vLmF1dGgwLmNvbS8iLCJzdWIiOiJhdXRoMHw1ZDdhNTI3MTc2ZmIxNjBkOGQ5YjJlM2QiLCJhdWQiOlsiZGlzY292ZXJ5X2FwaSIsImh0dHBzOi8vc21hcnRjb2x1bWJ1c29zLWRlbW8uYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTU2ODk5NTAyOSwiZXhwIjoxNTY4OTk1MDg5LCJhenAiOiJzZmU1Zlp6RlhzdjVnSVJYejhWM3prUjdpYVpCTXZMMCIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwifQ.P6mLUyh9R5GVRgkGXSiOSLGHm4LM9Xi25dEKMUZqLSeRFgOKgTTHrV_SRtHXWgjbCUlI_2tobHWk0C1hIb2_CfkIhCTXsKwt81Q0iKy-L56fsPax5ZNnVl31uiueMPqKQ5M-41AHtDnGe1P4VsJDoBLUNr8C_yUQRJWA1V9E2LKZsmnauRtAm_S89T7KCNxhA9M75zCcm--dLwtu9PpjlQHfQvbxTT0Ujh0uguJXgrOpmlamO8Fc_cYYiiOr2Jw_Dfk5U0Xkz0gswYc11Jli5Klz1P0iZJGwr6ctgGoZzPd55biUGlyNeR_MAgBEmemMBV5Utk_lE7sx0JnrAMhIUw"
  end

  def valid_jwks() do
    %{
      "keys" => [
        %{
          "kid" => "abc",
          "x5c" => ["123"]
        },
        %{
          "alg" => "RS256",
          "e" => "AQAB",
          "kid" => "ODIyRENDNEYzQkVEMjAyNzE4RTNCMTM2QTNGRjU2NUU3QzZDQUQ1OQ",
          "kty" => "RSA",
          "n" =>
            "tXBHbJU_DN0IB2iBp0H4zj4fdG1r-Kjk3fUQA6qjVSLtgPkfRHHO6jYyvEldkdIp_eaPeSG_295Iwl4QXYzqG-JoVN3kLQLIdvPAGIDklYkjhGw8rXohAcyQauL868DBFnml_G1I2yxr4KFV81ATnDKqFdZWnbj77GIThRdOH-t_pjzT4adzCZ2M29IudgIH9U_YXWASNo08D3fGOKDX133kV392KIGno_qkFCnKCl1Uk1825ReLxeFAv3wu5K0wWcBoekpcR7IE3n_JwPpbNx0dxHGkUtQe_vQaBikfrwSc6dLkf1j6BA4nL3PCyOdp2gxE8ziJqFq56u0-fanffw",
          "use" => "sig",
          "x5c" => [
            "MIIDFzCCAf+gAwIBAgIJY3KHA8an5FmsMA0GCSqGSIb3DQEBCwUAMCkxJzAlBgNVBAMTHnNtYXJ0Y29sdW1idXNvcy1kZW1vLmF1dGgwLmNvbTAeFw0xOTA5MTIxNDA2NTdaFw0zMzA1MjExNDA2NTdaMCkxJzAlBgNVBAMTHnNtYXJ0Y29sdW1idXNvcy1kZW1vLmF1dGgwLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALVwR2yVPwzdCAdogadB+M4+H3Rta/io5N31EAOqo1Ui7YD5H0Rxzuo2MrxJXZHSKf3mj3khv9veSMJeEF2M6hviaFTd5C0CyHbzwBiA5JWJI4RsPK16IQHMkGri/OvAwRZ5pfxtSNssa+ChVfNQE5wyqhXWVp24++xiE4UXTh/rf6Y80+GncwmdjNvSLnYCB/VP2F1gEjaNPA93xjig19d95Fd/diiBp6P6pBQpygpdVJNfNuUXi8XhQL98LuStMFnAaHpKXEeyBN5/ycD6WzcdHcRxpFLUHv70GgYpH68EnOnS5H9Y+gQOJy9zwsjnadoMRPM4iahauertPn2p338CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUnZ4D8M8v/YpdCn8emk79jkjNkUMwDgYDVR0PAQH/BAQDAgKEMA0GCSqGSIb3DQEBCwUAA4IBAQCkRrGVUIa/uCrt0UdCM+RSI7yEIcPGIbpWKq8URVwcgwcoz7ytTkB0Wkd0724rVAV79IUi2tQHQMMqNm/omPKcT+0zPeZT7c+mD+qHtNiAd35VZJifc7moh7GYygwR9MOR9P1LipzgwuLLIb4RHy2GJ43svJgISms94ie5mRXjvkv2XFwvVbi2mHCTQWD4RgH91HI0sNRp5HYbSGUNZzDcdDAp9ZBmUKpFRAX6f4Zot3mTTNtHHyLF5sd9gUnkvqa2vX+h3rtqJ4sTdzi2NUBst7Btb/7xWvl1tBpA5V7Vjvg3SPKVirHGqnfmdWAdMk3dzJxl7fO0Of1b6NTiB/vZ"
          ],
          "x5t" => "ODIyRENDNEYzQkVEMjAyNzE4RTNCMTM2QTNGRjU2NUU3QzZDQUQ1OQ"
        }
      ]
    }
  end

end

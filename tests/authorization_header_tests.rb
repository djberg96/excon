require 'shindo'

Shindo.tests('Excon basics (Authorization data redacted)') do
  cases = [
    ['user & pass', 'http://user1:pass1@foo.com/', 'Basic dXNlcjE6cGFzczE='],
    ['email & pass', 'http://foo%40bar.com:pass1@foo.com/', 'Basic Zm9vQGJhci5jb206cGFzczE='],
    ['user no pass', 'http://three_user@foo.com/', 'Basic dGhyZWVfdXNlcjo='],
    ['pass no user', 'http://:derppass@foo.com/', 'Basic OmRlcnBwYXNz'],
    ['regular auth', 'http://regularauthtest.org', 'Authorization OmRlcnBwYXNz'],
    ['proxy auth', 'http://proxyauthtest.org', 'Proxy-Authorization OmRlcnBwYXNz']
  ]
  cases.each do |desc,url,auth_header|
    conn = Excon.new(url, :headers => auth_header)

    test("authorization header concealed for #{desc}") do
      !conn.inspect.include?(auth_header)
    end

    if conn.data[:password]
      test("password param concealed for #{desc}") do
        !conn.inspect.include?(conn.data[:password])
      end
    end

    test("password param remains correct for #{desc}") do
      conn.data[:password] == URI.parse(url).password
    end

  end
end

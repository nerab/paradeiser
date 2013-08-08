guard 'bundler' do
  watch('Gemfile')
  watch(%r|^.*\.gemspec|)
end

guard 'minitest' do
  watch(%r|^test/unit/test_(.*)\.rb|){|m| "test/unit/test_#{m[1]}.rb"}
  watch(%r|^lib/*\.rb|){'test'}
  watch(%r|^lib/.*/*\.rb|){'test'}
  watch(%r{^lib/.*/([^/]+)\.rb$}){|m| "test/unit/test_#{m[1]}.rb"}
  watch(%r|^test/helper\.rb|){'test'}
  watch(%r{^lib/.*/views/(.*)/[^/]+\.erb$}){|m| "test/unit/test_#{m[1]}_view.rb"}

  # Integration tests
  watch(%r{^bin/([^/]+)$}){|m| "test/integration/test_#{m[1]}.rb"}
  watch(%r|^test/integration/test_(.*)\.rb|){|m| "test/integration/test_#{m[1]}.rb"}
end

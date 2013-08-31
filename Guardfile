guard 'bundler' do
  watch('Gemfile')
  watch(%r|^.*\.gemspec|)
end

group 'unit' do
  guard 'minitest' do
    watch(%r|^test/unit/test_(.*)\.rb|){|m| "test/unit/test_#{m[1]}.rb"}
    watch(%r|^lib/*\.rb|){'test/unit'}
    watch(%r|^lib/.*/*\.rb|){'test/unit'}
    watch(%r{^lib/.*/([^/]+)\.rb$}){|m| "test/unit/test_#{m[1]}.rb"}
    watch(%r|^test/helper\.rb|){'test/unit'}
    watch(%r{^lib/.*/views/(.*)/[^/]+\.erb$}){|m| "test/unit/test_#{m[1]}_view.rb"}
  end
end

group 'integration' do
  guard 'minitest' do
    watch(%r{^bin/([^/]+)$}){"test/integration"}
    watch(%r|^test/integration/test_(.*)\.rb|){|m| "test/integration/test_#{m[1]}.rb"}
    watch(%r|^test/lib/*\.rb|){'test/integration'}
  end
end

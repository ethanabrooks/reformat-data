require 'json'

fname = 'locationSearch_gradingtest.txt'

def updateLabels(semantics, column)
  begin
    json = JSON.parse(column)
    labels = json.fetch('p')
  rescue JSON::ParserError, KeyError
    return column
  end
  json['p'] = labels.zip(semantics).collect do |label, semantic|
    label['l'] = "#{label['l']},#{semantic}"
    label
  end
  return JSON.dump json
end


File.open(fname) do |src|
  File.open('new.' << fname, 'w') do |dest|
    src.each do |line|
      columns = line.split("\t")
      semantics = columns.collect do |column|
         JSON.parse(column) rescue nil
      end.compact.flat_map do |json|
        json.fetch('spans', []).collect do |span|
          span.fetch('s', 'default')
        end
      end
      dest.puts columns
                    .map { |column| updateLabels(semantics, column) }
                    .join "\t"
    end
  end
end
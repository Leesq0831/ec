json.areas @provinces do |p|
	json.name "#{p.name}"
	json.code "#{p.id.to_s}"

	json.sub p.cities do |c|
		json.name "#{c.name}"
		json.code "#{c.id}"

		json.sub c.districts do |d|
			json.name "#{d.name}"
			json.code d.id.to_s
		end
	end
end
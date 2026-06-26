function rndb(low, high)
  return flr(rnd(high - low + 1) + low)
end

function any_button_pressed()
	for i=0,5 do
		if btnp(i) then
			return true
		end
	end
	return false
end

-- function _tni(current_index, table_length)
--   return current_index % table_length + 1
-- end

function _unpack_split(values_as_text)
  return unpack(split(values_as_text))
end
delays = {}

function delay(frames, fn)
    add(delays, { t = frames, fn = fn })
end

function update_delays()
    for d in all(delays) do
        d.t -= 1
        if d.t <= 0 then
            d.fn()
            del(delays, d)
        end
    end
end
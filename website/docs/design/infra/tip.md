# Tips

Here are some personal small tips if you want to modify or debug the infra layer.

## Utilize timeline tracing

You know, the one that is visualized in `chrome://tracing`. I have written down how to capture it [here](../../benchmark/gather-data). I have personally find it quite helpful (much more helpful than debugging or print-based logging).

They can be create from both C++ engine (`TRACE_EVENT0` etc) and Dart (`Timeline` etc).

## Compare with theory

I have faced a ton of weird cases along the journey to 60FPS when analyzing timeline. The cause and solution vary a lot, but when get lost, try to compare the experimental result with the theory, and see why and how to solve the difference. Hopefully this will make the mind cleaner.
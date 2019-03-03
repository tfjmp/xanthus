module Pegasus
CAMFLOW_START = %q{%{
camflow -a true
}}

CAMFLOW_STOP = %q{%{
camflow -a false
sleep 20
}}
end

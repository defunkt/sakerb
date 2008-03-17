# inferred_routes plugin
#
# lib/inferred_routes.rb
#
# Version 0.1.1
#
# David A. Black
#
# November 1, 2006
#
# This is simply the define_url_helper method from ActionController,
# with a big hack from me to make it infer routes.

      class ActionController::Routing::RouteSet::NamedRouteCollection 

          def define_url_helper(route, name, kind, options)
            selector = url_helper_name(name, kind)
            
            # The segment keys used for positional paramters

            segment_keys = route.segments.collect do |segment|
              segment.key if segment.respond_to? :key
            end.compact
            hash_access_method = hash_access_name(name, kind)
            @module.send :module_eval, <<-end_eval # We use module_eval to avoid leaks
              def #{selector}(*args)

# Hack from dblack.
                keys = #{segment_keys.inspect}

                sing = keys[-1] == :id
                items = keys.map {|k| k.to_s.sub(/_id$/, '') }

                if sing
                  items.pop
                  until args.size == keys.size
                    args.unshift(args[0].send(items.pop))
                  end
                else
                  if args.size == 1
# items: ["scratchpad","page"]
# args:  [@page]
                    if args[0].class.name == items[-1].classify
                      base_obj = args[0]
                      items.pop
                    else
# items: ["scratchpad", "page"]
# args:  [@idea]
                      base_obj = args.shift
                    end
                    items.reverse.each do |item|
                      args.unshift(base_obj.send(item))
                      base_obj = args[0]
                    end 
                  end
                end 
# End hack.
                opts = if args.empty? || Hash === args.first
                  args.first || {}
                else
                  # allow ordered parameters to be associated with corresponding
                  # dynamic segments, so you can do
                  #
                  #   foo_url(bar, baz, bang)
                  #
                  # instead of
                  #
                  #   foo_url(:bar => bar, :baz => baz, :bang => bang)

                  args.zip(#{segment_keys.inspect}).inject({}) do |h, (v, k)|
                    h[k] = v
                    h
                  end
                end
                url_for(#{hash_access_method}(opts))
              end
            end_eval
            @module.send(:protected, selector)
            helpers << selector
          end
        end

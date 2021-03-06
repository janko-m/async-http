# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'readable'

require 'async/queue'

module Async
	module HTTP
		module Body
			# A dynamic body which you can write to and read from.
			class Writable < Readable
				def initialize
					@queue = Async::Queue.new
					
					@count = 0
					
					@finished = false
					@stopped = nil
				end
				
				def empty?
					@finished
				end
				
				# Read the next available chunk.
				def read
					# I'm not sure if this is a good idea (*).
					# if @stopped
					# 	raise @stopped
					# end
					
					return if @finished
					
					unless chunk = @queue.dequeue
						@finished = true
					end
					
					return chunk
				end
				
				# Cause the next call to write to fail with the given error.
				def stop(error)
					@stopped = error
				end
				
				# Write a single chunk to the body. Signal completion by calling `#finish`.
				def write(chunk)
					# If the reader breaks, the writer will break.
					# The inverse of this is less obvious (*)
					if @stopped
						raise @stopped
					end
					
					# TODO should this yield if the queue is full?
					
					@count += 1
					@queue.enqueue(chunk)
				end
				
				alias << write
				
				# Signal that output has finished.
				def finish
					@queue.enqueue(nil)
				end
				
				def inspect
					"\#<#{self.class} #{@count} chunks written#{@finished ? ', finished' : ''}>"
				end
			end
		end
	end
end

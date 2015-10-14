part of stream_transformers;

/// Projects each element of an observable sequence into zero or more buffers which are produced based on element count information.
///
/// **Example:**
///
///     var controller = new StreamController();
///
///     var stream = controller.stream;
///
///     var buffered = stream.transform(new BufferWithCount(2, 1));
///
///     controller.add(1);
///     controller.add(2);
///     controller.add(3);
///     controller.add(4);
///     controller.close();
///
///     buffered.listen(print); // Prints: [1, 2], [2, 3], [3, 4], [4]
class BufferWithCount<T> implements StreamTransformer<T, T> {
  
  final int _count;
  final int _skip;
  
  BufferWithCount(int count, [int skip = 0]) : 
    _count = count, 
    _skip = skip {
    if (_skip >= _count) throw new ArgumentError('skip cannot be larger than count, [skip=$_skip and count=$count]');
  }
  
  Stream<T> bind(Stream<T> stream) {
    List<T> buffer = <T>[];
    
    return _bindStream(like: stream, onListen: (EventSink<List<T>> sink) {
      
      void done() {
        if (buffer.isNotEmpty) sink.add(buffer);
        sink.close();
      }
      
      void onData(T data) {
        buffer.add(data);
        
        if (buffer.length == _count) {
          sink.add(buffer);
          buffer = buffer.sublist(buffer.length - _skip);
        }
      }

      return stream.listen(onData, onError: sink.addError, onDone: done);
    });
  }
  
}
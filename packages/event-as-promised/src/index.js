import Promise from 'bluebird'
import { EventEmitter } from 'events'

export default class EventAsPromised extends EventEmitter {
  constructor () {
    super()
  }
  getEventLength (name) {
    if (this._events[name] && !this._events[name][0]) return 1
    if (this._events[name]) return this._events[name].length
    return 0
  }
  on (name, fn) {
    return super.on(name, ({args, internalEvent}) => {
      return Promise.resolve(fn(...args))
        .then(result => internalEvent.emit(`${name}_internal`, result))
        .catch(err => internalEvent.emit(`${name}_internal_error`, err))
    })
  }
  emit (...args) {
    let name = args[0]
    args.shift()
    let internalEvent = new EventEmitter()
    return new Promise((resolve, reject) => {
      let data = []
      let awaiting = this.getEventLength(name)
      if (!awaiting) return resolve([])
      super.emit(name, {args, internalEvent})
      internalEvent.on(`${name}_internal`, (result) => {
        data.push(result)
        if (data.length === awaiting) {
          return resolve(data)
        }
      })
      internalEvent.on(`${name}_internal_error`, reject)
    })
  }
}

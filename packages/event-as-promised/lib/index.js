'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _toConsumableArray2 = require('babel-runtime/helpers/toConsumableArray');

var _toConsumableArray3 = _interopRequireDefault(_toConsumableArray2);

var _getPrototypeOf = require('babel-runtime/core-js/object/get-prototype-of');

var _getPrototypeOf2 = _interopRequireDefault(_getPrototypeOf);

var _classCallCheck2 = require('babel-runtime/helpers/classCallCheck');

var _classCallCheck3 = _interopRequireDefault(_classCallCheck2);

var _createClass2 = require('babel-runtime/helpers/createClass');

var _createClass3 = _interopRequireDefault(_createClass2);

var _possibleConstructorReturn2 = require('babel-runtime/helpers/possibleConstructorReturn');

var _possibleConstructorReturn3 = _interopRequireDefault(_possibleConstructorReturn2);

var _get2 = require('babel-runtime/helpers/get');

var _get3 = _interopRequireDefault(_get2);

var _inherits2 = require('babel-runtime/helpers/inherits');

var _inherits3 = _interopRequireDefault(_inherits2);

var _bluebird = require('bluebird');

var _bluebird2 = _interopRequireDefault(_bluebird);

var _events = require('events');

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var EventAsPromised = function (_EventEmitter) {
  (0, _inherits3.default)(EventAsPromised, _EventEmitter);

  function EventAsPromised() {
    (0, _classCallCheck3.default)(this, EventAsPromised);
    return (0, _possibleConstructorReturn3.default)(this, (0, _getPrototypeOf2.default)(EventAsPromised).call(this));
  }

  (0, _createClass3.default)(EventAsPromised, [{
    key: 'getEventLength',
    value: function getEventLength(name) {
      if (this._events[name] && !this._events[name][0]) return 1;
      if (this._events[name]) return this._events[name].length;
      return 0;
    }
  }, {
    key: 'on',
    value: function on(name, fn) {
      return (0, _get3.default)((0, _getPrototypeOf2.default)(EventAsPromised.prototype), 'on', this).call(this, name, function (_ref) {
        var args = _ref.args;
        var internalEvent = _ref.internalEvent;

        return _bluebird2.default.resolve(fn.apply(undefined, (0, _toConsumableArray3.default)(args))).then(function (result) {
          return internalEvent.emit(name + '_internal', result);
        }).catch(function (err) {
          return internalEvent.emit(name + '_internal_error', err);
        });
      });
    }
  }, {
    key: 'emit',
    value: function emit() {
      var _this2 = this;

      for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
        args[_key] = arguments[_key];
      }

      var name = args[0];
      args.shift();
      var internalEvent = new _events.EventEmitter();
      return new _bluebird2.default(function (resolve, reject) {
        var data = [];
        var awaiting = _this2.getEventLength(name);
        if (!awaiting) return resolve([]);
        (0, _get3.default)((0, _getPrototypeOf2.default)(EventAsPromised.prototype), 'emit', _this2).call(_this2, name, { args: args, internalEvent: internalEvent });
        internalEvent.on(name + '_internal', function (result) {
          data.push(result);
          if (data.length === awaiting) {
            return resolve(data);
          }
        });
        internalEvent.on(name + '_internal_error', reject);
      });
    }
  }]);
  return EventAsPromised;
}(_events.EventEmitter);

exports.default = EventAsPromised;
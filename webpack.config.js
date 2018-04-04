const path = require('path');

const elmSource = path.resolve(__dirname);

module.exports = [{
  entry: {
    'app': [
      './src/index.ts'
    ]
  },
  resolve: {
    extensions: ['.ts', '.js']
  },
  output: {
    path: path.resolve(__dirname + '/build'),
    filename: '[name].js',
  },

  module: {
    rules: [
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader?name=[name].[ext]',
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: 'elm-webpack-loader?verbose=true&warn=true&cwd=' + elmSource,
      },
      {
        test: /\.ts$/,
        loader: 'ts-loader'
      }
    ],

    noParse: /\.elm$/,
  },

  devServer: {
    inline: true,
    stats: {
      colors: true
    },
  },
}];

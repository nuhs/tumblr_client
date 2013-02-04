require_relative '../spec_helper'

describe Tumblr::Client::Post do

  let(:client) { Tumblr::Client.new }
  let(:blog_name) { 'blogname' }
  let(:file_path) { '/path/to/the/file' }
  let(:file_data) { 'lol cats' }
  let(:source)    { 'the source' }
  let(:post_id)   { 42 }

  describe :delete do

    context 'when deleting a post' do

      before do
        client.should_receive(:post).once.with("v2/blog/#{blog_name}/post/delete", {
          :id => post_id
        })
      end

      it 'should setup a delete properly' do
        client.delete blog_name, post_id
      end

    end

  end

  describe :photo do

    context 'when passing an option which is not allowed' do

      it 'should raise an error' do
        lambda {
          client.photo blog_name, :not => 'an option'
        }.should raise_error ArgumentError
      end

    end

    context 'when passing data different ways' do

      before do
        fakefile = OpenStruct.new :read => file_data
        File.stub(:open).with(file_path, 'rb').and_return(fakefile)
        client.should_receive(:post).once.with("v2/blog/#{blog_name}/post", {
          'data[0]' => file_data,
          :type => 'photo'
        }).and_return('post')
      end

      it 'should be able to pass data as an array of filepaths' do
        r = client.photo blog_name, :data => [file_path]
        r.should == 'post'
      end

      it 'should be able to pass data as a single filepath' do
        r = client.photo blog_name, :data => file_path
        r.should == 'post'
      end

      it 'should be able to pass an array of raw data' do
        r = client.photo blog_name, :data_raw => [file_data]
        r.should == 'post'
      end

      it 'should be able to pass raw data' do
        r = client.photo blog_name, :data_raw => file_data
        r.should == 'post'
      end

    end

    context 'when passing source different ways' do

      it 'should be able to be passed as a string' do
        client.should_receive(:post).once.with("v2/blog/#{blog_name}/post", {
          :source => source,
          :type => 'photo'
        })
        client.photo blog_name, :source => source
      end

      it 'should be able to be passed as an array' do
        client.should_receive(:post).once.with("v2/blog/#{blog_name}/post", {
          'source[0]' => source,
          'source[1]' => source,
          :type => 'photo'
        })
        client.photo blog_name, :source => [source, source]
      end

    end

    context 'when passing colliding options' do

      it 'should get an error when passing data & source' do
        lambda {
          client.photo blog_name, :data => 'hi', :source => 'bye'
        }.should raise_error ArgumentError
      end

      it 'should get an error when passing data & raw_data' do
        lambda {
          client.photo blog_name, :raw_data => 'hi', :data => 'bye'
        }.should raise_error ArgumentError
      end

    end

  end

end
